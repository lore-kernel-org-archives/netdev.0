From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [net] bonding: use return instead of goto
Date: Thu, 4 Feb 2016 14:26:22 -0500
Message-ID: <20160204192622.GD50535@redhat.com>
References: <1454480122-32501-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: j.vosburgh@gmail.com, netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43677 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932976AbcBDT0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 14:26:23 -0500
Content-Disposition: inline
In-Reply-To: <1454480122-32501-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 03, 2016 at 06:15:22AM +0000, Zhang Shengju wrote:
> Replace 'goto' with 'return' to remove unnecessary check at label:
> err_undo_flags.

I think you're going to have to explain how you came to the conclusion
that the check isn't necessary.

-- 
Jarod Wilson
jarod@redhat.com
