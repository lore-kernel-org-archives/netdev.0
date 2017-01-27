From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211 debugfs: Cleanup some checkpatch issues
Date: Fri, 27 Jan 2017 22:00:20 +0100
Message-ID: <1485550820.14579.2.camel@sipsolutions.net>
References: <20170127192603.GA13522@gmail.com>
         (sfid-20170127_203712_578214_221D21FF)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Pichugin Dmitry <smokeman85@gmail.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127192603.GA13522@gmail.com> (sfid-20170127_203712_578214_221D21FF)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-01-27 at 22:26 +0300, Pichugin Dmitry wrote:
> This fixes the checkpatch.pl warnings:
> * Macros should not use a trailing semicolon.
> * Spaces required around that '='.
> * Symbolic permissions 'S_IRUGO' are not preferred.
> * Macro argument reuse 'buflen' - possible side-effects

I really see no point in any of this.

johannes
