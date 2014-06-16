From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-sysfs: Report link speed only when possible
Date: Mon, 16 Jun 2014 01:11:48 -0700 (PDT)
Message-ID: <20140616.011148.2001285440663327901.davem@davemloft.net>
References: <539AC237.40402@redhat.com>
	<20140613.130350.1729507484821351177.davem@davemloft.net>
	<539E9D93.9040405@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mprivozn@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <539E9D93.9040405@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Privoznik <mprivozn@redhat.com>
Date: Mon, 16 Jun 2014 09:32:35 +0200

> On 13.06.2014 22:03, David Miller wrote:
>> From: Michal Privoznik <mprivozn@redhat.com>
>> Date: Fri, 13 Jun 2014 11:19:51 +0200
>>
>>> So if I were developing brand new application I could say: I'm
>>> dropping all this workaround code and have it clean and require say
>>> 3.16 kernel at least.
>>
>> Then your application wouldn't be usable on %99 of systems for a long
>> long time.
>>
> 
> How come? The application is going to be usable for as long as
> library/kernel APIs won't change.

Because %99 of users are using a distribution kernel which is definitely
going to be pre-3.16 for years.
