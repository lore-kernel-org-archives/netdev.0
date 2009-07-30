From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] net/netlabel: Add kmalloc NULL tests
Date: Thu, 30 Jul 2009 10:59:00 -0700 (PDT)
Message-ID: <20090730.105900.232424702.davem@davemloft.net>
References: <200907301032.20318.paul.moore@hp.com>
	<Pine.LNX.4.64.0907301637570.8734@ask.diku.dk>
	<200907301053.37416.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia@diku.dk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: paul.moore@hp.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752099AbZG3R6z@vger.kernel.org>
In-Reply-To: <200907301053.37416.paul.moore@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Thu, 30 Jul 2009 10:53:37 -0400

> On Thursday 30 July 2009 10:38:19 am Julia Lawall wrote:
>> From: Julia Lawall <julia@diku.dk>
>>
>> The test on map4 should be a test on map6.
>>
>> The semantic match that finds this problem is as follows:
>> (http://www.emn.fr/x-info/coccinelle/)
 ...
>> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> Much better, thank you.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

Applied, thanks.
