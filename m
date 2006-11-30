From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 07:19:12 +0100
Message-ID: <20061130061912.GB2003@elte.hu>
References: <2f2083e145b6.456de740@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757554AbWK3GU6@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Content-Disposition: inline
In-Reply-To: <2f2083e145b6.456de740@fnal.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Wenji Wu <wenji@fnal.gov> wrote:

> > That yield() will need to be removed - yield()'s behaviour is truly 
> > awfulif the system is otherwise busy.  What is it there for?
> 
> Please read the uploaded paper, which has detailed description.

do you have any URL for that?

	Ingo
