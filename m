From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: jme: fix suspend/resume on JMC260
Date: Mon, 22 Feb 2016 23:42:34 -0500 (EST)
Message-ID: <20160222.234234.1952119173455287427.davem@davemloft.net>
References: <1456187572-2964-1-git-send-email-diego.viola@gmail.com>
	<CAOMZO5Br8mBWOFcdw6i7=VBKtwQsVFMzEYK=CoowG90ExUCCGg@mail.gmail.com>
	<CA+ToGPGLc38aVdkSYsx_QtgFADouZQsRBxD_U-m0fy79fJgCFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, cooldavid@cooldavid.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	richard.weinberger@gmail.com, pavel@ucw.cz, rjw@rjwysocki.net
To: diego.viola@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+ToGPGLc38aVdkSYsx_QtgFADouZQsRBxD_U-m0fy79fJgCFA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Diego Viola <diego.viola@gmail.com>
Date: Mon, 22 Feb 2016 22:58:48 -0300

> On Mon, Feb 22, 2016 at 10:46 PM, Fabio Estevam <festevam@gmail.com> wrote:
>> On Mon, Feb 22, 2016 at 9:32 PM, Diego Viola <diego.viola@gmail.com> wrote:
>>> Signed-off-by: Diego Viola <diego.viola@gmail.com>
>>
>> You should write a commit log.
> 
> I thought about including the link to my bug report:
> https://bugzilla.kernel.org/show_bug.cgi?id=112351
> 
> What else would you suggest I add to the commit message?

The commit message is where you describe the change you are making.

This includes exactly what you are fixing, how you are doing it, and why
you are doing it that way.

Empty commit log messages are %99.99999 of the time completely
inappropriate.
