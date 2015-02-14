From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] at86rf230: assign wait_for_completion_timeout to appropriately typed var
Date: Sat, 14 Feb 2015 13:48:47 -0800
Message-ID: <E22FEF8C-DB92-43EE-859C-D8C0D72C3A9F@holtmann.org>
References: <1423385700-11125-1-git-send-email-hofrat@osadl.org> <20150208093428.GA10594@omega> <20150214213422.GB4035@omega>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Nicholas Mc Guire <hofrat@osadl.org>, linux-wpan@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150214213422.GB4035@omega>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alex,

>>> return type of wait_for_completion_timeout is unsigned long not int.
>>> As rc is used here only for wait_for_completion_timeout the type is simply
>>> changed to unsigned long.
>>> 
>>> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
>> 
>> Acked-by: Alexander Aring <alex.aring@gmail.com>
>> 
>> Marcel, can you please queue this for bluetooth-next. Should be able to
>> apply against bluetooth-next. Thanks.
>> 
> 
> Marcel, ping.

my apologizes, but this one never made it to my archive. Please resend and I apply it.

Regards

Marcel
