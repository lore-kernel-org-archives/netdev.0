From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/5] ipv4_tunnels: Modularize ipv4 tunneling.
Date: Tue, 8 Jan 2013 13:16:58 -0800
Message-ID: <CALnjE+rGteBfudTniF+A49s_EPSQFA+fTuakEDUSW54SvAM1ag@mail.gmail.com>
References: <1357612292-1682-1-git-send-email-pshelar@nicira.com>
	<CAJZOPZK1wwno3wvu30v_HGm--R-SOYEP+SjK-sOc6F40iGb0QA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1191672549=="
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAJZOPZK1wwno3wvu30v_HGm--R-SOYEP+SjK-sOc6F40iGb0QA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============1191672549==
Content-Type: multipart/alternative; boundary=20cf303b40c3514b2004d2cd77b1

--20cf303b40c3514b2004d2cd77b1
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Jan 8, 2013 at 1:10 PM, Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Tue, Jan 8, 2013 at 4:31 AM, Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> wrote:
> > Following patch series restructure GRE and IPIP tunneling code
> > to make it modular. It adds ip_tunnel module which acts as
> > generic tunneling layer which has common code. I have patch
> > to do same for VXLAN too. [..]
>
> Can you be more specific re the vxlan patch?
>
>
I am in process of updating VXLAN patches, I will send new version soon. I
have earlier version posted on openvswitch dev mailing list last month.

Thanks,
Pravin.

--20cf303b40c3514b2004d2cd77b1
Content-Type: text/html; charset=ISO-8859-1

<div dir="ltr"><br><div class="gmail_extra"><br><br><div class="gmail_quote">On Tue, Jan 8, 2013 at 1:10 PM, Or Gerlitz <span dir="ltr">&lt;<a href="mailto:or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" target="_blank">or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org</a>&gt;</span> wrote:<br>
<blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div class="im">On Tue, Jan 8, 2013 at 4:31 AM, Pravin B Shelar &lt;<a href="mailto:pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org">pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org</a>&gt; wrote:<br>

&gt; Following patch series restructure GRE and IPIP tunneling code<br>
&gt; to make it modular. It adds ip_tunnel module which acts as<br>
&gt; generic tunneling layer which has common code. I have patch<br>
</div>&gt; to do same for VXLAN too. [..]<br>
<br>
Can you be more specific re the vxlan patch?<br>
<span class="HOEnZb"><font color="#888888"><br></font></span></blockquote><div><br></div><div style>I am in process of updating VXLAN patches, I will send new version soon. I have earlier version posted on openvswitch dev mailing list last month.</div>
<div style><br></div><div style>Thanks,</div><div style>Pravin.</div></div></div></div>

--20cf303b40c3514b2004d2cd77b1--

--===============1191672549==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1191672549==--
