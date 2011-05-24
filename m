From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 0/9] strict user copy checks on x86_64
Date: Tue, 24 May 2011 16:33:33 -0700
Message-ID: <4DDC404D.8030505@zytor.com>
References: <1305244212-19183-1-git-send-email-sboyd@codeaurora.org> <4DDC232F.7080005@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Intel Linux Wireless <ilw@linux.intel.com>,
	linux-scsi@vger.kernel.org, x86@kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DDC232F.7080005@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/24/2011 02:29 PM, Stephen Boyd wrote:
> 
> It looks like 1, 2, 4, 6, and 7 got picked up. Should I resend the left
> over patches with appropriate acked-bys and tags? Would it be
> appropriate to push this through your tree?
> 

I was first going to think I'd pick up 8 and 9 in tip, but since 9 is
cross-architecture, Andrew's tree might be better.

Acked-by: H. Peter Anvin <hpa@zytor.com>

	-hpa
