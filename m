From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24-rc6-mm1
Date: Thu, 3 Jan 2008 08:51:54 +1100
Message-ID: <20080102215154.GA13911@gondor.apana.org.au>
References: <20071222233056.d652743e.akpm@linux-foundation.org> <64bb37e0712230827m7d368e2l3174f3b4396d09c1@mail.gmail.com> <64bb37e0712281453y4aac82b7h7acc8ec314ca6e3e@mail.gmail.com> <20071228150746.42b3bbc0.akpm@linux-foundation.org> <64bb37e0712290851r6d41768dk270e47884713a3de@mail.gmail.com> <20071230013021.GA13603@gondor.apana.org.au> <64bb37e0712291934o77a3d365h56c9c31ac8437469@mail.gmail.com> <64bb37e0712311215x519b10e9kd51eb745b3b7290a@mail.gmail.com> <20080101120406.GA27209@gondor.apana.org.au> <64bb37e0801021029u1735bb9eta53906b123abf577@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: Torsten Kaiser <just.for.lkml@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756766AbYABVxM@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <64bb37e0801021029u1735bb9eta53906b123abf577@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 02, 2008 at 07:29:59PM +0100, Torsten Kaiser wrote:
>
> Vanilla 2.6.24-rc6 seems stable. I did not see any crash or warnings.

OK that's great.  The next step would be to try excluding specific git
trees from mm to see if they make a difference.

The two specific trees of interest would be git-nfsd and git-net.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
