From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] zd1211rw: replace ZD_ASSERT with lockdep_assert_held()
Date: Thu, 11 Sep 2014 08:53:27 +0200
Message-ID: <1410418407.1825.0.camel@jlt4.sipsolutions.net>
References: <1407827133-29493-1-git-send-email-sanjeev_sharma@mentor.com>
	 <FDC088D3B5555644AE135ED28A7ABDE94DF2FDC2@EU-MBX-02.mgc.mentorg.com>
	 (sfid-20140819_083957_833442_DEE44B0A) <1408707084.4349.0.camel@jlt4.sipsolutions.net>
	 <FDC088D3B5555644AE135ED28A7ABDE94DF4D490@EU-MBX-02.mgc.mentorg.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "dsd@gentoo.org" <dsd@gentoo.org>,
	"kune@deine-taler.de" <kune@deine-taler.de>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Sharma, Sanjeev" <Sanjeev_Sharma@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <FDC088D3B5555644AE135ED28A7ABDE94DF4D490@EU-MBX-02.mgc.mentorg.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-09-11 at 04:02 +0000, Sharma, Sanjeev wrote:
> -----Original Message-----
> From: Johannes Berg [mailto:johannes@sipsolutions.net] 
> Sent: Friday, August 22, 2014 5:01 PM
> To: Sharma, Sanjeev
> Cc: dsd@gentoo.org; kune@deine-taler.de; linville@tuxdriver.com; linux-wireless@vger.kernel.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH] zd1211rw: replace ZD_ASSERT with lockdep_assert_held()
> 
> On Tue, 2014-08-19 at 06:39 +0000, Sharma, Sanjeev wrote:
> > Ping for review the patch.
> 
> > Make sure it compiles ...
> 
> Any update on this patch ?

I don't know, do you have any update for us?

Since your patch hasn't changed, it still cannot be compiled (when
lockdep is enabled). Make sure you test your patch before you submit it
again please.

johannes
