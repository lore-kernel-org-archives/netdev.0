From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: [5/5] e1000e: Avoid receiver overrun interrupt bursts
Date: Tue, 24 Oct 2017 11:39:10 -0600
Message-ID: <238D36BF-473B-4F9A-BDCF-97544F2FDF3F@redfish-solutions.com>
References: <20170721183627.13373-5-bpoirier@suse.com>
 <DDD41C67-CDF2-4443-9F49-0DC5489D9243@redfish-solutions.com>
 <20170919194102.h2nu72evbqhpu765@f1.synalogic.ca>
 <20171024172027.onfcusdcicxqnfjp@csclub.uwaterloo.ca>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Benjamin Poirier <bpoirier@suse.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        linux-kernel@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024172027.onfcusdcicxqnfjp@csclub.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Oct 24, 2017, at 11:20 AM, Lennart Sorensen <lsorense@csclub.uwaterloo.ca> wrote:
> 
> On Tue, Sep 19, 2017 at 09:41:02PM +0200, Benjamin Poirier wrote:
>> On 2017/09/19 12:38, Philip Prindeville wrote:
>>> Hi.
>>> 
>>> We’ve been running this patchset (all 5) for about as long as they’ve been under review… about 2 months.  And in a burn-in lab with heavy traffic.
>>> 
>>> We’ve not seen a single link-flap in hundreds of ours of saturated traffic.
>>> 
>>> Would love to see some resolution soon on this as we don’t want to ship a release with unsanctioned patches.
>>> 
>>> Is there an estimate on when that might be?
>> 
>> The patches have been added to Jeff Kirsher's next-queue tree. I guess
>> they will be submitted for v4.15 which might be released in early
>> 2018...
>> http://phb-crystal-ball.org/
> 
> And then they will be submitted to linux-stable so this long standing
> regression can be fixed, right?
> 


Let’s hope!

-Philip
