From: Avi Kivity <avi@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 20:53:53 +0200
Message-ID: <4B3115C1.4070303@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu> <4B3103B4.4070708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754636AbZLVSzM@vger.kernel.org>
In-Reply-To: <4B3103B4.4070708@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/22/2009 07:36 PM, Gregory Haskins wrote:
>
>> Gregory, it would be nice if you worked _much_ harder with the KVM folks
>> before giving up.
>>      
> I think the 5+ months that I politely tried to convince the KVM folks
> that this was a good idea was pretty generous of my employer.  The KVM
> maintainers have ultimately made it clear they are not interested in
> directly supporting this concept (which is their prerogative), but are
> perhaps willing to support the peripheral logic needed to allow it to
> easily interface with KVM.  I can accept that, and thus AlacrityVM was born.
>    

Review pointed out locking issues with xinterface which I have not seen 
addressed.  I asked why the irqfd/ioeventfd mechanisms are insufficient, 
and you did not reply.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
