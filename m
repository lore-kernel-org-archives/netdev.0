From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: Latest 3.6.6 are not compiling due tg3 network driver,
 hwmon_device_unregister
Date: Wed, 14 Nov 2012 19:43:32 -0800
Message-ID: <50A464E4.1080105@broadcom.com>
References: <8b566c4a9ee622737212dc17291ee238@visp.net.lb>
 <50A4606D.4020402@broadcom.com>
 <alpine.DEB.2.00.1211141929510.14414@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"Denys Fedoryshchenko" <denys@visp.net.lb>,
	"Michael Chan" <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David Rientjes" <rientjes@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1211141929510.14414@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 11/14/2012 07:30 PM, David Rientjes wrote:
> On Wed, 14 Nov 2012, Nithin Nayak Sujir wrote:
>
>> This was fixed by
>>
>> commit de0a41484c47d783dd4d442914815076aa2caac2
>> Author: Paul Gortmaker <paul.gortmaker@windriver.com>
>> Date:   Mon Oct 1 11:43:49 2012 -0400
>>
>>      tg3: unconditionally select HWMON support when tg3 is enabled.
>>
> Would you mind submitting this for stable by following the procedure
> described in Documentation/stable_kernel_rules.txt?
>

Will do. Thank you for bringing this to our attention.

Nithin.
