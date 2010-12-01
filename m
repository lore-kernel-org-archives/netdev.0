From: Eric Cooper <ecc@cmu.edu>
Subject: Re: [PATCH v2] add netdev led trigger
Date: Tue, 30 Nov 2010 19:03:00 -0500
Message-ID: <20101201000300.GJ21496@localhost>
References: <1290998056-8310-1-git-send-email-ecc@cmu.edu>
 <87ipzgl9k8.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	Richard Purdie <rpurdie@rpsys.net>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87ipzgl9k8.fsf@basil.nowhere.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 29, 2010 at 11:15:51AM +0100, Andi Kleen wrote:
> Using the device name as an identifier is not reliable, they may not
> be unique.

I'm confused about this -- how else can the user specify the desired network
interface?

> rwlocks are deprecated.

In favor of what?  Should I use a spinlock?

Thanks for the feedback.

-- 
Eric Cooper             e c c @ c m u . e d u
