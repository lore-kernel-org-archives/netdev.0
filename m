From: Martin Bligh <mbligh@mbligh.org>
Subject: Re: 2.6.18-mm2 boot failure on x86-64
Date: Wed, 04 Oct 2006 18:08:19 -0700
Message-ID: <45245B03.2070803@mbligh.org>
References: <20060928014623.ccc9b885.akpm@osdl.org> <20061004170659.f3b089a8.akpm@osdl.org> <20061005005124.GA23408@in.ibm.com> <200610050257.53971.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vgoyal@in.ibm.com, Andrew Morton <akpm@osdl.org>,
	Steve Fox <drfickle@us.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kmannth@us.ibm.com,
	Andy Whitcroft <apw@shadowen.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751300AbWJEBIV@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200610050257.53971.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>>I think most likely it would crash on 2.6.18. Keith mannthey had reported
>>a different crash on 2.6.18-rc4-mm2 when this patch was introduced first
>>time. Following is the link to the thread.
> 
> 
> Then maybe trying 2.6.17 + the patch and then bisect between that and -rc4?

I think it's fixed already in -git22, or at least it is for the IBM box
reporting to test.kernel.org. You might want to try that one ...

M.
