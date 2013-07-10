From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next v2 1/3] net: rename include/net/ll_poll.h to
 include/net/busy_poll.h
Date: Wed, 10 Jul 2013 17:00:48 +0300
Message-ID: <51DD6910.80207@linux.intel.com>
References: <20130710121349.12906.85078.stgit@ladj378.jer.intel.com> <51DD5F05.6030206@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jonathan Corbet <corbet@lwn.net>,
	e1000-devel@lists.sourceforge.net,
	Eilon Greenstein <eilong@broadcom.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51DD5F05.6030206@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/2013 16:17, Arend van Spriel wrote:
> On 07/10/2013 02:13 PM, Eliezer Tamir wrote:
>> Rename the file and correct all the places where it is included.
>> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> ---
>>   include/net/busy_poll.h                         |  183
>> +++++++++++++++++++++++
>>   include/net/ll_poll.h                           |  183
>> -----------------------
> 
> Did you use -M command line option with 'git format-patch'?

No, I'm using stg so I was not aware of the option.
If this is how we expect people to send patches, why isn't this the default.

I will resend shortly with -M

Thanks,
Eliezer
