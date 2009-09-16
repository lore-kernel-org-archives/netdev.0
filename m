From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [E1000-devel] [BUG 2.6.30+] e100 sometimes causes oops during
	resume
Date: Wed, 16 Sep 2009 23:17:55 +0200
Message-ID: <20090916211755.GA2048@bizet.domek.prywatny>
References: <20090915120538.GA26806@bizet.domek.prywatny> <13830B75AD5A2F42848F92269B11996F5BF592C3@orsmsx509.amr.corp.intel.com> <20090916014448.GA1070@bizet.domek.prywatny> <4AB1536F.9070205@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karol Lewandowski <karol.k.lewandowski@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Graham, David" <david.graham@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:23053 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537AbZIPVR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 17:17:57 -0400
Content-Disposition: inline
In-Reply-To: <4AB1536F.9070205@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 16, 2009 at 02:06:55PM -0700, Graham, David wrote:
> Karol Lewandowski wrote:
>>
>> I can test, or rather -- start testing this tommorow, if this makes
>> sense to you.
>>
> Yes please Karol, test with 6905b1f1...removed.

Ok.


> I will continue testing  
> here too on 2.6.31, though I have not had a repro yet. And are you  
> performing a standby or hibernate, I want to be sure that I'm resuming  
> from the same state.

I don't use hibernate, I always suspend to ram.

Thanks.
