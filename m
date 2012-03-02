From: jeewan girewal <jeewan.girewal@gmail.com>
Subject: Want to add IP options into IP header,
	unable to resolve symbol
Date: Fri, 2 Mar 2012 23:44:14 +0200
Message-ID: <CAPpZ4vca4YntvCEgddJE7+0y9ePSKzqVFyuRJq3fmi8u2bMM3Q@mail.gmail.com>
References: <CAPpZ4vfHMzez8RLPabN3Dzu4t1dkaDPncS8kwZ15q_KattCL0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0014120775843487533=="
To: netfilter@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	bart.de.schuymer@pandora.be, netfilter-devel@vger.kernel.org,
	shemminger@vyatta.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAPpZ4vfHMzez8RLPabN3Dzu4t1dkaDPncS8kwZ15q_KattCL0A@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============0014120775843487533==
Content-Type: multipart/alternative; boundary=14dae934116557747304ba497ae2

--14dae934116557747304ba497ae2
Content-Type: text/plain; charset=ISO-8859-1

Hi,

I want to use the function defined in in net/ip_options.c file like
ip_options_compile, ip_options_build in my netfilter module. I want to put
options into IP packet header. I have inserted the header file that
declares these function. I have used EXPORT_SYMBOL, but I get warning,
"ip_options_compile" undefined. Any suggestions will be greatly respected.
I am using Ubuntu 11.10. uname -a: 3.0.0-16-generic. Is there a way to make
this symbol visible for newer kernel?

-Jeewan

--14dae934116557747304ba497ae2
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><div class=3D"gmail_quote">Hi,<br><br>I want to use the function define=
d in in net/ip_options.c file like ip_options_compile, ip_options_build in =
my netfilter module. I want to put options into IP packet header. I have in=
serted the header file that declares these function. I have used EXPORT_SYM=
BOL, but I get warning, &quot;ip_options_compile&quot; undefined. Any sugge=
stions will be greatly respected. I am using Ubuntu 11.10. uname -a: 3.0.0-=
16-generic. Is there a way to make this symbol visible for newer kernel?<sp=
an class=3D"HOEnZb"><font color=3D"#888888"><br>

<br>-Jeewan<br>
</font></span></div><br>

--14dae934116557747304ba497ae2--

--===============0014120775843487533==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/bridge
--===============0014120775843487533==--
