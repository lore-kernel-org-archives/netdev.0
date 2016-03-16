From: Jasmine Strong <jas@eero.com>
Subject: Re: [RFCv2 0/3] mac80211: implement fq codel
Date: Wed, 16 Mar 2016 12:48:39 -0700
Message-ID: <CAGyitvMDEUiNx7HD=XKjXNHnFvZ_gxD_BbQx3AP-57_+dBeD4A@mail.gmail.com>
References: <1458123478-1795-1-git-send-email-michal.kazior@tieto.com>
 <CA+BoTQ=65mHN5iLnZjTE+tyEG7nfmCx4NZNbGRF6+VpRaNmOYw@mail.gmail.com>
 <CAA93jw5cUaj_qM+CYHHoRaghLDLC+BUgF4AjT=Oec+SB-zb74g@mail.gmail.com>
 <CAA93jw6tDdiYuginPbUY1DFJLiDxofHMFN6j2BvQPabPmBtuRw@mail.gmail.com>
 <20160316185531.GA1771@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1550777900743441972=="
Cc: Network Development <netdev@vger.kernel.org>,
 linux-wireless <linux-wireless@vger.kernel.org>,
 "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
 "codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
 make-wifi-fast@lists.bufferbloat.net
To: Bob Copeland <me@bobcopeland.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <20160316185531.GA1771@localhost>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
 <mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
 <mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Errors-To: codel-bounces@lists.bufferbloat.net
Sender: "Codel" <codel-bounces@lists.bufferbloat.net>
List-Id: netdev.vger.kernel.org

--===============1550777900743441972==
Content-Type: multipart/alternative; boundary=001a11345c0c113546052e2fce2f

--001a11345c0c113546052e2fce2f
Content-Type: text/plain; charset=UTF-8

BK usually has 0 txop, so it doesn't do aggregation.

On Wed, Mar 16, 2016 at 11:55 AM, Bob Copeland <me@bobcopeland.com> wrote:

> On Wed, Mar 16, 2016 at 11:36:31AM -0700, Dave Taht wrote:
> > That is the sanest 802.11e queue behavior I have ever seen!  (at both
> > 6 and 300mbit! in the ath10k patched mac test)
>
> Out of curiosity, why does BE have larger latency than BK in that chart?
> I'd have expected the opposite.
>
> --
> Bob Copeland %% http://bobcopeland.com/
>
> _______________________________________________
> ath10k mailing list
> ath10k@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/ath10k
>

--001a11345c0c113546052e2fce2f
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">BK usually has 0 txop, so it doesn&#39;t do aggregation.</=
div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">On Wed, Mar 1=
6, 2016 at 11:55 AM, Bob Copeland <span dir=3D"ltr">&lt;<a href=3D"mailto:m=
e@bobcopeland.com" target=3D"_blank">me@bobcopeland.com</a>&gt;</span> wrot=
e:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-l=
eft:1px #ccc solid;padding-left:1ex"><span class=3D"">On Wed, Mar 16, 2016 =
at 11:36:31AM -0700, Dave Taht wrote:<br>
&gt; That is the sanest 802.11e queue behavior I have ever seen!=C2=A0 (at =
both<br>
&gt; 6 and 300mbit! in the ath10k patched mac test)<br>
<br>
</span>Out of curiosity, why does BE have larger latency than BK in that ch=
art?<br>
I&#39;d have expected the opposite.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
Bob Copeland %% <a href=3D"http://bobcopeland.com/" rel=3D"noreferrer" targ=
et=3D"_blank">http://bobcopeland.com/</a><br>
</font></span><div class=3D"HOEnZb"><div class=3D"h5"><br>
_______________________________________________<br>
ath10k mailing list<br>
<a href=3D"mailto:ath10k@lists.infradead.org">ath10k@lists.infradead.org</a=
><br>
<a href=3D"http://lists.infradead.org/mailman/listinfo/ath10k" rel=3D"noref=
errer" target=3D"_blank">http://lists.infradead.org/mailman/listinfo/ath10k=
</a><br>
</div></div></blockquote></div><br></div>

--001a11345c0c113546052e2fce2f--

--===============1550777900743441972==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29kZWwgbWFp
bGluZyBsaXN0CkNvZGVsQGxpc3RzLmJ1ZmZlcmJsb2F0Lm5ldApodHRwczovL2xpc3RzLmJ1ZmZl
cmJsb2F0Lm5ldC9saXN0aW5mby9jb2RlbAo=

--===============1550777900743441972==--
