From: Chris Friesen <cfriesen@nortel.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 21 Jun 2005 22:44:16 -0600
Message-ID: <42B8ECA0.5060904@nortel.com>
References: <Pine.LNX.4.44.0506211642290.21812-100000@bluewest.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, Rick Jones <rick.jones2@hp.com>,
        netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
In-Reply-To: <Pine.LNX.4.44.0506211642290.21812-100000@bluewest.scyld.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Donald Becker wrote:
> On Wed, 22 Jun 2005, Andi Kleen wrote:
> 
> 
>>>While much has changed since then, the same basic parameters remain
>>>   - cache line size
>>
>>In 96 we had 32 byte cache lines. These days 64-128 are common,
>>with some 256 byte cache line systems around.
> 
> 
> Good point.
> I believe that the most common line size is 64 bytes for L1 cache.

If I recall, G4 chips are 32 bytes, and G5s are 128 bytes.  Most current 
x86 chips are 64 bytes though.

Chris
