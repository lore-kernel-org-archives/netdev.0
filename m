From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: Re: [PATCH v2 1/1] drivers: net: cpsw: Prevent NUll pointer
 dereference with two PHYs
Date: Tue, 19 Apr 2016 19:38:08 -0400
Message-ID: <20160419193808.29dc51c3.drivshin.allworx@gmail.com>
References: <57165269.40207@ti.com>
	<20160419131443.7a3b3ef7.drivshin.allworx@gmail.com>
	<57167C79.20205@ti.com>
	<20160419.184339.1558043853032502121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: andrew.goodbody@cambrionix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	mugunthanvnm@ti.com, tony@atomide.com
To: David Miller <davem@davemloft.net>, grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160419.184339.1558043853032502121.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Apr 2016 18:43:39 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Grygorii Strashko <grygorii.strashko@ti.com>
> Date: Tue, 19 Apr 2016 21:44:09 +0300
> 
> > May be you can send revert + your patch 1 (only fix for this issue).
> > 
> > Dave, Does that sound good to you?  
> 
> Sure.

OK, I will hopefully have that ready tomorrow evening.

Anything in particular I should mention in the revert commit message?
I didn't find a discussion on it, other than the earlier statement that 
"it breaks boot on many TI boards".
