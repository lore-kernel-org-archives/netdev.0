From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless 2012-01-04
Date: Wed, 4 Jan 2012 11:31:10 -0500
Message-ID: <20120104163109.GF2540@tuxdriver.com>
References: <20120104155816.GE2540@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120104155816.GE2540@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 04, 2012 at 10:58:16AM -0500, John W. Linville wrote:

> I was hesitant to include the rtlwifi fix, but settled on inclusion
> because it was a product of a recent ginormous thread about the
> intersection of firmware loading and suspend/resume.  Plus it fixes
> a bug report in the Red Hat Bugzilla. :-) If you don't think it is
> worthy, let me know and I'll drop it from this release.

It looks like this could generate a build warning...

	http://marc.info/?l=linux-wireless&m=132569396407866&w=2

I'm getting cold feet on this one.  I withdraw this pull request --
new one to follow soon!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
