From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 16/26] libceph: Use skcipher
Date: Tue, 26 Jan 2016 19:33:52 +0800
Message-ID: <20160126113352.GA21159@gondor.apana.org.au>
References: <20160124131021.GA31153@gondor.apana.org.au>
 <E1aNKYy-0008E6-GI@gondolin.me.apana.org.au>
 <CAOi1vP9jmMYHR21UeAO175susZ5V74vcXyoxwayBVSTFHxjhBQ@mail.gmail.com>
 <20160126105455.GA19674@gondor.apana.org.au>
 <CAOi1vP9kB5a-JeZ1PriwyQO0XH4Qh3UKidp==NPvVw-AsL=uqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ecryptfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-f2fs-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ceph Development <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Lars Ellenberg <drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>,
	open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Ilya Dryomov <idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOi1vP9kB5a-JeZ1PriwyQO0XH4Qh3UKidp==NPvVw-AsL=uqw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2016 at 12:29:57PM +0100, Ilya Dryomov wrote:
>
> LGTM.  You want to take it through crypto?

That's probably the easiest route since I'd like to take the first
patch through cryptodev.

Thanks,
-- 
Email: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
