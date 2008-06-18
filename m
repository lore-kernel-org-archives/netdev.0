From: "John Rigby" <jcrigby@gmail.com>
Subject: Re: [PATCH 1/2] fs_enet: fix checkpatch.pl problems
Date: Wed, 18 Jun 2008 07:29:17 -0600
Message-ID: <4b73d43f0806180629o5d85d0b0yf48018088e728975@mail.gmail.com>
References: <1213743794-3537-1-git-send-email-jrigby@freescale.com>
	<1213743794-3537-2-git-send-email-jrigby@freescale.com>
	<fa686aa40806172220u13d4397cn51f7f98e020408aa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0973554059=="
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	Sam Ravnborg <sam@ravnborg.org>, jeff@garzik.org, netdev@vger.kernel.org
To: "Grant Likely" <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <fa686aa40806172220u13d4397cn51f7f98e020408aa@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============0973554059==
Content-Type: multipart/alternative;
	boundary="----=_Part_708_19955640.1213795757453"

------=_Part_708_19955640.1213795757453
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I agree, I'll separate the fec_t -> struct fec changes out.

On Tue, Jun 17, 2008 at 11:20 PM, Grant Likely <grant.likely@secretlab.ca>
wrote:

> On Tue, Jun 17, 2008 at 5:03 PM, John Rigby <jrigby@freescale.com> wrote:
> > Fixed all errors and warnings that checkpatch.pl
> > reports if this was a new submission.
> > Also changed instances of fec_t to struct fec in
> > mac-fec.c and mii-fec.c.
>
> Nit: checkpatch is not law; particularly in the case of whitespace
> change.  Personally, I think cleaning up whitespace in this regard
> causes more problems than it solves.  Plus, it makes the important
> change (fec_t -> struct fec) get lost in a see of unimportant ones
> which makes for hard reviewing.
>
> But I must sleep now; I'll review your other patch tomorrow.
>
> Cheers,
> g.
>
> --
> Grant Likely, B.Sc., P.Eng.
> Secret Lab Technologies Ltd.
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev
>

------=_Part_708_19955640.1213795757453
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I agree, I&#39;ll separate the fec_t -&gt; struct fec changes out.<br><br><div class="gmail_quote">On Tue, Jun 17, 2008 at 11:20 PM, Grant Likely &lt;<a href="mailto:grant.likely@secretlab.ca">grant.likely@secretlab.ca</a>&gt; wrote:<br>
<blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;"><div class="Ih2E3d">On Tue, Jun 17, 2008 at 5:03 PM, John Rigby &lt;<a href="mailto:jrigby@freescale.com">jrigby@freescale.com</a>&gt; wrote:<br>

&gt; Fixed all errors and warnings that checkpatch.pl<br>
&gt; reports if this was a new submission.<br>
&gt; Also changed instances of fec_t to struct fec in<br>
&gt; mac-fec.c and mii-fec.c.<br>
<br>
</div>Nit: checkpatch is not law; particularly in the case of whitespace<br>
change. &nbsp;Personally, I think cleaning up whitespace in this regard<br>
causes more problems than it solves. &nbsp;Plus, it makes the important<br>
change (fec_t -&gt; struct fec) get lost in a see of unimportant ones<br>
which makes for hard reviewing.<br>
<br>
But I must sleep now; I&#39;ll review your other patch tomorrow.<br>
<br>
Cheers,<br>
g.<br>
<font color="#888888"><br>
--<br>
Grant Likely, B.Sc., P.Eng.<br>
Secret Lab Technologies Ltd.<br>
</font><div><div></div><div class="Wj3C7c">_______________________________________________<br>
Linuxppc-dev mailing list<br>
<a href="mailto:Linuxppc-dev@ozlabs.org">Linuxppc-dev@ozlabs.org</a><br>
<a href="https://ozlabs.org/mailman/listinfo/linuxppc-dev" target="_blank">https://ozlabs.org/mailman/listinfo/linuxppc-dev</a><br>
</div></div></blockquote></div><br>

------=_Part_708_19955640.1213795757453--

--===============0973554059==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============0973554059==--
