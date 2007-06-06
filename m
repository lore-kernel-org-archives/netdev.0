From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: warnings in git-wireless
Date: Wed, 06 Jun 2007 07:14:51 -0700
Message-ID: <4666C15B.4050007@linux.intel.com>
References: <20070605020614.3f06b2ab.akpm@linux-foundation.org> <20070605115701.GA5391@tuxdriver.com> <4665C393.2000507@linux.intel.com> <20070606072016.GA4805@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:43086 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757022AbXFFQPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 12:15:54 -0400
In-Reply-To: <20070606072016.GA4805@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Tue, Jun 05, 2007 at 01:12:03PM -0700, James Ketrenos wrote:
>> Yes, we certainly don't want a driver to be "near mainline" that does 
>> things that the rest of the kernel and other drivers are doing.  We should 
>> force them to stay out-of-tree until any and everything is resolved.  
>> Heaven forbid that the code should be merged, contributed, and improved 
>> upon as a community.
>>
>> You'd think these guys were trying to enable folks with a driver so they 
>> can use the hardware they bought or something.  Its almost laughable.  What 
>> idiots.
> 
> Maybe you should make sure your companies publishes specs

I'm flattered that you think I am high enough at Intel to do that.  If it was in my power, accurate and complete specifications would be available for all of Intel's hardware--for everyone.  I doubt you'll find a single Linux developer at Intel who is not fighting to try and reach that goal, including myself.

The reality is, however, (and this may shock you) I am not a vice president or head of a major division at Intel.  Its true.  Intel doesn't do what I want just because I snap my fingers and say it should be so.

Instead, we try and do what we can -- enable people with a driver (and a community to contribute into) so that the hardware they purchased can operate to its fullest potential on Linux.  We realize within the community that some areas are difficult for people outside of Intel to initially contribute to given the lack of specs.  However, there are vast quantities of features and functionality that can be enabled and improved given nothing more than the driver sources.

Anyway, its obvious from your emails that our efforts are not sufficient and you seem to resent that we're even trying.  I apologize.

If you'd like to submit patches to help us make the perfect driver, we're very willing to review and merge those in.

James
