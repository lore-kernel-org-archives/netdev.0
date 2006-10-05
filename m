From: Andi Kleen <ak@suse.de>
Subject: Re: 2.6.18-mm2 boot failure on x86-64
Date: Thu, 5 Oct 2006 02:57:53 +0200
Message-ID: <200610050257.53971.ak@suse.de>
References: <20060928014623.ccc9b885.akpm@osdl.org> <20061004170659.f3b089a8.akpm@osdl.org> <20061005005124.GA23408@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Steve Fox <drfickle@us.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kmannth@us.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751292AbWJEA6F@vger.kernel.org>
To: vgoyal@in.ibm.com
In-Reply-To: <20061005005124.GA23408@in.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I think most likely it would crash on 2.6.18. Keith mannthey had reported
> a different crash on 2.6.18-rc4-mm2 when this patch was introduced first
> time. Following is the link to the thread.

Then maybe trying 2.6.17 + the patch and then bisect between that and -rc4?

-Andi
