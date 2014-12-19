From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] net: drop the packet when fails to do software
 segmentation or header check
Date: Fri, 19 Dec 2014 03:16:21 +0008
Message-ID: <1418958501.8471.0@smtp.corp.redhat.com>
References: <1418882239-6720-1-git-send-email-jasowang@redhat.com>
	<20141218.153912.942123862967427213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141218.153912.942123862967427213.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, Dec 19, 2014 at 4:39 AM, David Miller <davem@davemloft.net> 
wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Thu, 18 Dec 2014 13:57:19 +0800
> 
>>  Fixes cecda693a969816bac5e470e1d9c9c0ef5567bca
> 
> Please correct this fixes tag, it should be of the form:
> 
> Fixes: $(SHA1) ("header text of commit message")
> 
> The SHA1 ID should be reduced to 12 digits of significance.

Ok, will post V2.
