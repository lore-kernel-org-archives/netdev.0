From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: O/M flags against 2.6.0-test1
Date: Thu, 24 Jul 2003 17:14:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F20766C.3060400@us.ibm.com>
References: <200307241443.SAA09525@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307241443.SAA09525@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

So people are ok with using struct ? Since it can be typecast as an array :-)

thanks,

- KK


kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> 
>>I'm not so sure about the "array," but anyway,
>>I don't think it is so ugly to use struct / offsetof.
> 
> 
> Just write a sample of code, printing all fields of struct
> and equivalent array, and you will see.
> 
> Well, I just know, that when iproute will do this, it will
> cast the struct to array in any case. It is dirty, but sane at least. :-)
> 
> Alexey
> 
