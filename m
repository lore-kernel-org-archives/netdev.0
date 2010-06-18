From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] socketcan: add a driver for FlexCAN controllers.
Date: Fri, 18 Jun 2010 14:19:01 +0200
Message-ID: <4C1B6435.6060809@grandegger.com>
References: <20100617105201.GA2015@bluebox.local>	<4C1B4098.3090800@grandegger.com>
	<20100618120044.GB2007@bluebox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Hans J. Koch" <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100618120044.GB2007-hikPBsva6T+Nj9Bq2fkWzw@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/18/2010 02:00 PM, Hans J. Koch wrote:
> On Fri, Jun 18, 2010 at 11:47:04AM +0200, Wolfgang Grandegger wrote:
>> Hi Hans-J=FCrgen,
>>
>> On 06/17/2010 12:52 PM, Hans J. Koch wrote:
>>> This adds a driver for FlexCAN based CAN controllers,
>>> e.g. found in Freescale i.MX35 SoCs.
>>>
>>> The original version of this driver was posted by Sascha Hauer in July =
2009:
>>> http://kerneltrap.org/mailarchive/linux-netdev/2009/7/29/6251621
>>>
>>> I took this version, added NAPI support, and fixed some problems found
>>> during testing. Well, here is the result. Please review.
>>
>> I briefly browsed the patch and various bits and pieces are missing or
>> not correctly implemented. Marc already pointed out a few of them:
> =

> Before we continue, we should address the fact that we now have two versi=
ons
> of the driver. It doesn't make sense to work on both.
> Just for the record, I knew that Marc was working on this, and offered
> cooperation in a private mail a few weeks ago. He never answered, so I ma=
de
> it work myself, and posted it as soon as I could. A few hours after he saw
> that, he came up with his version...
> =

> So, instead of continuing wasting engineering powers, you should decide
> which of the two versions is in the better shape already, and we continue
> working on that. I don't mind at all if you choose Marc's version. I'm
> not running after copyright lines, I just want to see flexcan in mainline
> as soon as possible.

Me too. Marc's version is definitely more up-to-date and should be taken
as starting point.

Wolfgang.
