From: Benjamin Poirier <bpoirier@suse.com>
Subject: Re: [5/5] e1000e: Avoid receiver overrun interrupt bursts
Date: Tue, 19 Sep 2017 21:41:02 +0200
Message-ID: <20170919194102.h2nu72evbqhpu765@f1.synalogic.ca>
References: <20170721183627.13373-5-bpoirier@suse.com>
 <DDD41C67-CDF2-4443-9F49-0DC5489D9243@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org,
        Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
To: Philip Prindeville <philipp_subx@redfish-solutions.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <DDD41C67-CDF2-4443-9F49-0DC5489D9243@redfish-solutions.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017/09/19 12:38, Philip Prindeville wrote:
> Hi.
> 
> We’ve been running this patchset (all 5) for about as long as they’ve been under review… about 2 months.  And in a burn-in lab with heavy traffic.
> 
> We’ve not seen a single link-flap in hundreds of ours of saturated traffic.
> 
> Would love to see some resolution soon on this as we don’t want to ship a release with unsanctioned patches.
> 
> Is there an estimate on when that might be?

The patches have been added to Jeff Kirsher's next-queue tree. I guess
they will be submitted for v4.15 which might be released in early
2018...
http://phb-crystal-ball.org/
