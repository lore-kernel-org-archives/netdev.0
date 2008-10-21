From: Aldo Maggi <sentiniate@tiscali.it>
Subject: Re: tcp_sack problem Re: [Bug 11721] after upgrade to 2.6.27 i
 cannot navigate
Date: Tue, 21 Oct 2008 07:26:30 +0200
Message-ID: <20081021072630.287eb1c8@topolino>
References: <bug-11721-11547@http.bugzilla.kernel.org/>
	<20081020154737.2D0CA108042@picon.linux-foundation.org>
	<20081020171530.GA2564@ami.dom.local>
	<20081020214818.09d88b48@topolino>
	<Pine.LNX.4.64.0810202323330.30254@wrl-59.cs.helsinki.fi>
	<20081020233419.78cd4390@topolino>
	<Pine.LNX.4.64.0810210036040.30254@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/8+sdk0avCul7E5cqlta4E5W"
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from averell.mail.tiscali.it ([213.205.33.55]:54579 "EHLO
	averell.mail.tiscali.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbYJUF0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 01:26:39 -0400
In-Reply-To: <Pine.LNX.4.64.0810210036040.30254@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/8+sdk0avCul7E5cqlta4E5W
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


[...]

> > 
> > i'm right now compiling the -27-rc1 kernel, on my pc it will take at
> > least 3 hrs (that is, it will finish 02.00 rome time :-D )
> 

ok! the new kernel with ilpo's patch works!!
please find herewith attached the tcpdump output on eth0 on topolino 
while on paperino kernel 2.6.27-rc1-git1 with ilpo patch was running ,
the three tcp files all set to 1

[...]

as soon as i come back home i will start compilation of 2.6.27.2 with
ilpo patch

thanks 
aldo

--MP_/8+sdk0avCul7E5cqlta4E5W
Content-Type: application/octet-stream;
 name=tcpdump_2-6-27-rc1-git1-ilpo-tcp_1
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=tcpdump_2-6-27-rc1-git1-ilpo-tcp_1

MDc6MTU6NDMuNzMzNTc0IElQIDE5Mi4xNjguMjU0LjEuNTc2MDQgPiAyMDQuMTUyLjE5MS41Ljgw
OiBTIDI5NjUxODg2MjM6Mjk2NTE4ODYyMygwKSB3aW4gNTg0MCA8bXNzIDE0NjAsc2Fja09LLHRp
bWVzdGFtcCAxNDUyMTQgMCxub3Asd3NjYWxlIDY+CgkweDAwMDA6ICAwMGEwIGM1NDMgNWZlYiAw
MDEwIDVhYzUgNjgxYyAwODAwIDQ1MDAgIC4uLkNfLi4uWi5oLi4uRS4KCTB4MDAxMDogIDAwM2Mg
MDczMSA0MDAwIDNmMDYgZWE0MiBjMGE4IGZlMDEgY2M5OCAgLjwuMUAuPy4uQi4uLi4uLgoJMHgw
MDIwOiAgYmYwNSBlMTA0IDAwNTAgYjBiZCAzMDBmIDAwMDAgMDAwMCBhMDAyICAuLi4uLlAuLjAu
Li4uLi4uCgkweDAwMzA6ICAxNmQwIGVkODYgMDAwMCAwMjA0IDA1YjQgMDQwMiAwODBhIDAwMDIg
IC4uLi4uLi4uLi4uLi4uLi4KCTB4MDA0MDogIDM3M2UgMDAwMCAwMDAwIDAxMDMgMDMwNiAgICAg
ICAgICAgICAgICAgNz4uLi4uLi4uLgowNzoxNTo0My45NDM4NjkgSVAgMTkyLjE2OC4yNTQuMS41
NzYwNCA+IDIwNC4xNTIuMTkxLjUuODA6IC4gYWNrIDE4ODc0NzA5Njggd2luIDkyIDxub3Asbm9w
LHRpbWVzdGFtcCAxNDUyNjcgMTA1NjQ5OTAxMT4KCTB4MDAwMDogIDAwYTAgYzU0MyA1ZmViIDAw
MTAgNWFjNSA2ODFjIDA4MDAgNDUwMCAgLi4uQ18uLi5aLmguLi5FLgoJMHgwMDEwOiAgMDAzNCAw
NzMyIDQwMDAgM2YwNiBlYTQ5IGMwYTggZmUwMSBjYzk4ICAuNC4yQC4/Li5JLi4uLi4uCgkweDAw
MjA6ICBiZjA1IGUxMDQgMDA1MCBiMGJkIDMwMTAgNzA4MCA4NTc4IDgwMTAgIC4uLi4uUC4uMC5w
Li54Li4KCTB4MDAzMDogIDAwNWMgMTg0YyAwMDAwIDAxMDEgMDgwYSAwMDAyIDM3NzMgM2VmOCAg
LlwuTC4uLi4uLi4uN3M+LgoJMHgwMDQwOiAgZTU0MyAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAuQwowNzoxNTo0My45NDQxMTAgSVAgMTkyLjE2OC4yNTQuMS41NzYwNCA+IDIw
NC4xNTIuMTkxLjUuODA6IFAgMDoyNDAoMjQwKSBhY2sgMSB3aW4gOTIgPG5vcCxub3AsdGltZXN0
YW1wIDE0NTI2NyAxMDU2NDk5MDExPgoJMHgwMDAwOiAgMDBhMCBjNTQzIDVmZWIgMDAxMCA1YWM1
IDY4MWMgMDgwMCA0NTAwICAuLi5DXy4uLlouaC4uLkUuCgkweDAwMTA6ICAwMTI0IDA3MzMgNDAw
MCAzZjA2IGU5NTggYzBhOCBmZTAxIGNjOTggIC4kLjNALj8uLlguLi4uLi4KCTB4MDAyMDogIGJm
MDUgZTEwNCAwMDUwIGIwYmQgMzAxMCA3MDgwIDg1NzggODAxOCAgLi4uLi5QLi4wLnAuLnguLgoJ
MHgwMDMwOiAgMDA1YyAxZTJlIDAwMDAgMDEwMSAwODBhIDAwMDIgMzc3MyAzZWY4ICAuXC4uLi4u
Li4uLi43cz4uCgkweDAwNDA6ICBlNTQzIDQ3NDUgNTQyMCAyZjIwIDQ4NTQgNTQ1MCAyZjMxIDJl
MzAgIC5DR0VULi8uSFRUUC8xLjAKCTB4MDA1MDogIDBkMGEgNTU3MyA2NTcyIDJkNDEgNjc2NSA2
ZTc0IDNhMjAgNzczMyAgLi5Vc2VyLUFnZW50Oi53Mwo=

--MP_/8+sdk0avCul7E5cqlta4E5W--
