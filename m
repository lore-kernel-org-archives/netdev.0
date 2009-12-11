From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v4] add the driver for Analog
 Devices Blackfin on-chip CAN controllers
Date: Fri, 11 Dec 2009 15:17:35 -0800 (PST)
Message-ID: <20091211.151735.11269330.davem@davemloft.net>
References: <1260524788-13103-1-git-send-email-21cnbao@gmail.com>
	<4B22183F.2070806@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
        oe-pJ9TYRvN+WE@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <4B22183F.2070806-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Date: Fri, 11 Dec 2009 11:00:31 +0100

> Barry Song wrote:
>> Signed-off-by: Barry Song <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Signed-off-by: H.J. Oertel <oe-pJ9TYRvN+WE@public.gmane.org>
>> ---
>>  -v4:
>>  1. request and release interrupts in open/close instead of in module load/unload
>>  2. use bfin_read16/write16 instead of common readw/writew
>>  3. fix "line over 80 characters" checkpatch warning
>>  4. fix other coding style issues required by Wolfgang Grandegger
> 
> David, here is my
> 
> Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O63ddJNmlsFzeA@public.gmane.org>

Applied, thanks everyone.
