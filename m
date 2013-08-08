From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Fri, 09 Aug 2013 01:11:40 +0400
Message-ID: <5204098C.9010402@cogentembedded.com>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com> <20130808210918.GE5502@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kumar Gaurav <kumargauravgupta3@gmail.com>, davem@davemloft.net,
	emilio@elopez.com.ar, mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130808210918.GE5502@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/09/2013 01:09 AM, Dan Carpenter wrote:

>> Removed IRQF_DISABLED as it's no-op and should be removed

> What?  No, that doesn't sound right.

    How about reading a comment to the definition of IRQF_DISABLED?

> regards,
> dan carpenter

WBR, Sergei

