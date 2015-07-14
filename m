From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [rhashtable] WARNING: CPU: 0 PID: 1 at lib/debugobjects.c:301
 __debug_object_init()
Date: Tue, 14 Jul 2015 10:50:26 +0200
Message-ID: <55A4CD52.5060104@iogearbox.net>
References: <20150714051957.GB19723@wfg-t540p.sh.intel.com> <20150714052136.GA20251@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	LKP <lkp@01.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150714052136.GA20251@wfg-t540p.sh.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/14/2015 07:21 AM, Fengguang Wu wrote:
> Sorry please ignore -- this no longer happen in linux-next, so should be fine.

Seen this before, this fixed it back then:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/lib/test_rhashtable.c?id=b7f5e5c7f8cedf6b69c9702d448cdf78ffc45c7b
