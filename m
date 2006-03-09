From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 1/4] net: percpufy frequently used vars -- add percpu_counter_mod_bh
Date: 09 Mar 2006 03:21:40 +0100
Message-ID: <p733bhswe6j.fsf@verdi.suse.de>
References: <20060308015808.GA9062@localhost.localdomain>
	<20060308015934.GB9062@localhost.localdomain>
	<20060307181301.4dd6aa96.akpm@osdl.org>
	<20060308202656.GA4493@localhost.localdomain>
	<20060308203642.GZ5410@kvack.org>
	<20060308210726.GD4493@localhost.localdomain>
	<20060308211733.GA5410@kvack.org>
	<20060308222528.GE4493@localhost.localdomain>
	<20060308150609.344c62fa.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bcrl@kvack.org, linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932711AbWCICVu@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060308150609.344c62fa.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> writes:
> 
> x86_64 is signed 32-bit!

I'll change it. You want signed 64bit?

-Andi
