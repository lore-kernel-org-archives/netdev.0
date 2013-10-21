From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: Re: [PATCH] mac80211: document IEEE80211_HW_SUPPORTS_HT_CCK_RATES
Date: Mon, 21 Oct 2013 13:46:51 +0200
Message-ID: <5265142B.5050000@free-electrons.com>
References: <1382251529-22540-1-git-send-email-michael.opdenacker@free-electrons.com> <1382350961.14310.42.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382350961.14310.42.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johannes,

On 10/21/2013 12:22 PM, Johannes Berg wrote:
> On Sun, 2013-10-20 at 08:45 +0200, Michael Opdenacker wrote:
>> This patch documents the IEEE80211_HW_SUPPORTS_HT_CCK_RATES flag
>> in ieee80211_hw_flags.
>>
>> Without this, you get countless warnings in "make htmldocs".
> I already have an equivalent patch with correct documentation :)

Great! Then let's use your patch :)

Thanks,

Michael.

-- 
Michael Opdenacker, CEO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
+33 484 258 098
