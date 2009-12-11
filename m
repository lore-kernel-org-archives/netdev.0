From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v4] add the driver for Analog Devices Blackfin on-chip
	CAN controllers
Date: Fri, 11 Dec 2009 11:43:21 +0100
Message-ID: <4B222249.2050304@grandegger.com>
References: <1260524788-13103-1-git-send-email-21cnbao@gmail.com>	<4B22183F.2070806@grandegger.com>
	<20091211.021033.211260458.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
	oe-pJ9TYRvN+WE@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20091211.021033.211260458.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> Date: Fri, 11 Dec 2009 11:00:31 +0100
> 
>> Barry Song wrote:
>>> Signed-off-by: Barry Song <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> Signed-off-by: H.J. Oertel <oe-pJ9TYRvN+WE@public.gmane.org>
>>> ---
>>>  -v4:
>>>  1. request and release interrupts in open/close instead of in module load/unload
>>>  2. use bfin_read16/write16 instead of common readw/writew
>>>  3. fix "line over 80 characters" checkpatch warning
>>>  4. fix other coding style issues required by Wolfgang Grandegger
>> David, here is my
>>
>> Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O63ddJNmlsFzeA@public.gmane.org>
>>
>> for this driver. There is just some minor issue with the copyright
>> below. IIRC, the merge window is still open.
> 
> The networking merge window is closed.  If I have to post a reference
> to this announcement I made one more freakin' time I'm going to be
> really angry:
> 
> http://marc.info/?l=linux-netdev&m=125988357131776&w=2
> 
> If people don't read the announcements I send to netdev, in particular
> the ones I prefix with "README" to show it's important, I might as
> well not do it at all.

The "README" prefix is a good thing. Now I know what to look for next time.

> Then you'll really have to guess what the current state of affairs
> is :-)
> 
> But it doesn't even matter for this case because we can take
> completely new drivers at any point in time, not just during
> the merge window.

OK, sorry for bothering you.

Thanks,

Wolfgang.
