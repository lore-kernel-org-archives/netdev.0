From: Jens Axboe <axboe@suse.de>
Subject: Re: e1000 Invalid truesize
Date: Wed, 26 Apr 2006 19:58:53 +0200
Message-ID: <20060426175853.GF5002@suse.de>
References: <F50A4280B6033741B1DD2B4E902258B13F4EAD@orsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.virtualhost.dk ([195.184.98.160]:15391 "EHLO virtualhost.dk")
	by vger.kernel.org with ESMTP id S932318AbWDZR6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 13:58:13 -0400
To: "Ronciak, John" <john.ronciak@intel.com>
Content-Disposition: inline
In-Reply-To: <F50A4280B6033741B1DD2B4E902258B13F4EAD@orsmsx411.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26 2006, Ronciak, John wrote:
> Please follow what has been happening on netdev.  Dave Miller added this
> BUG to 2.6.17-rc as something we (Intel LAD) pointed out to them.  Jeff
> Garzik has, as of this morning, queued our e1000 patch for this.  He's
> been a little behind.

Ah ok, I guess I should have searched there first. I was just grasping
at straws, hoping perhaps some new debug aid exposed my e1000 problem
and it finally could get fixed.

> If you want to know more about the problem, please read the entire
> netdev discussion about this.

Thanks.

-- 
Jens Axboe

