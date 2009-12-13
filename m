From: Avi Kivity <avi@redhat.com>
Subject: Re: KVM related crash
Date: Sun, 13 Dec 2009 12:15:24 +0200
Message-ID: <4B24BEBC.2020207@redhat.com>
References: <ec55d96f0912090600u4ff02e06m1506530d4161f280@mail.gmail.com> <20091212191101.669ba881.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adam Huffman <adam.huffman.lkml@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20091212191101.669ba881.akpm@linux-foundation.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/13/2009 05:11 AM, Andrew Morton wrote:
> (networking cc's added)
>
> On Wed, 9 Dec 2009 14:00:04 +0000 Adam Huffman<adam.huffman.lkml@gmail.com>  wrote:
>
>    
>> Have seen multiple crashes on a new Dell Precision T7500 workstation,
>> seemingly related to KVM:
>>      
> Looks like a networking crash to me - that CPU just happened to be
> running some KVM code when the interrupt happened.
>    

Yes - and I've seen a similar report earlier (also with kvm).

-- 
error compiling committee.c: too many arguments to function

