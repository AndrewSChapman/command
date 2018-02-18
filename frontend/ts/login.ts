import Vue from 'vue'

const Component = Vue.component ('login-component', {
    template: `
        <form id="frmLogin" name="frmLogin" method="post" v-on:submit.prevent="handleLogin">
            <label for="loginUsername">Username</label>
            <input type="text" id="loginUsername" name="username" required />

            <label for="loginPassword">Password</label>
            <input type="password" id="loginPassword" name="password" required />

            <input type="submit" value="Login &gt;&gt;" />
        </form>    
    `,
    methods: {
        handleLogin: function(e: any) {
            e.preventDefault();
            alert('HI THERE');
        }
    }
});

new Vue({
    el: '#app'
});  
