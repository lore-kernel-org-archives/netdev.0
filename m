From: "Ihar 'Philips' Filipau" <filia@softhome.net>
Subject: Re: TOE brain dump
Date: Mon, 04 Aug 2003 22:06:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2EBCCA.5060708@softhome.net>
References: <1060015518.1103.399.camel@jzny.localdomain>	 <3F2EAA78.60202@softhome.net> <1060026149.1102.411.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1060026149.1102.411.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
>>   It just takes only 3k. And it handles some special (read - 
>>proprietary) functions too - some bugs of some other pieces of hardware. 
>>NPU does all stuff by itself, but sometimes we need to extract 
>>configuration information which is direct to us, for example.
> 
> 
> Please provide me a pointer if you can - I am very interested in the 2G
> code space you mention.
> 

   I'm not sure - actually as I wrote - immediately gone checking specs.
   try: 
http://www.vitesse.com/products/categories.cfm?family_id=5&category_id=16

   ...

   [ Okay I got to docs server. ] You are right - It has limit of 4K 
insns == 16k of executable memory.

   Sorry for confusion :(

   We really can address a lot of memory - we have 32MB for routing info 
and configuration - but for execution only 16kB of memory is available...
