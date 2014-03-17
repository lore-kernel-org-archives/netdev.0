From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Mon, 17 Mar 2014 15:46:11 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1403171545170.5451@gmail.com>
References: <87siqlnol8.fsf@nemi.mork.no> <20140314090525.GB3200@reaktio.net> <87ob19nndo.fsf@nemi.mork.no> <20140314125934.GC3200@reaktio.net> <87vbvgnbv3.fsf@nemi.mork.no> <20140314142559.GD3200@reaktio.net> <87k3btm57a.fsf@nemi.mork.no>
 <20140317115919.GK3200@reaktio.net> <20140317124555.GL3200@reaktio.net> <87y509kluc.fsf@nemi.mork.no> <20140317131731.GM3200@reaktio.net> <87txawlx9h.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-683441087-1275653754-1395067573=:5451"
Cc: =?ISO-8859-15?Q?Pasi_K=E4rkk=E4inen?= <pasik-X3B1VOXEql0@public.gmane.org>,
	=?ISO-8859-15?Q?Thomas_Sch=E4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87txawlx9h.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---683441087-1275653754-1395067573=:5451
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

I admite you, Bjorn: that's talent.
Let's see how it goes.
And congratulations to Pasik also.




On Mon, 17 Mar 2014, Bjørn Mork wrote:

==Date: Mon, 17 Mar 2014 15:23:22
==From: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
==To: Pasi Kärkkäinen <pasik-X3B1VOXEql0@public.gmane.org>
==Cc: Thomas Schäfer <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
==    netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
==    Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
==Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276 problem
==
==Pasi Kärkkäinen <pasik-X3B1VOXEql0@public.gmane.org> writes:
==> On Mon, Mar 17, 2014 at 02:15:23PM +0100, Bjørn Mork wrote:
==>
==>> I still don't know for sure, but I do hope this bug is the real cause of
==>> the problems you are having.  I'll send you a patch for testing as soon
==>> as it is ready.
==>> 
==>
==> Sure. I'll be happy to test the patch!
==
==I ended up with a simple revert of the buggy commit, except for a
==conflict due to unrelated context changes.  This seemed like the
==cleanest approach given that this fix also needs to go to stable.
==
==Attaching the first version.  Please give it a try if you can. I've
==tested it somewhat myself and it doesn't seem to break anything.  Since
==it's a simple revert, there isn't really that much that could go wrong
==here...
==
==
==Bjørn
==
==
---683441087-1275653754-1395067573=:5451--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
