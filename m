From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH next-next 0/2] can: cc770: add support
 for the Bosch CC770 and Intel AN82527
Date: Wed, 30 Nov 2011 13:10:25 +0100
Message-ID: <4ED61D31.5090305@grandegger.com>
References: <1322136448-7311-1-git-send-email-wg@grandegger.com>	<20111129.183950.1327835803051184146.davem@davemloft.net>	<4ED5CF14.4020502@hartkopp.net>
	<4ED5E94F.8010403@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4ED5E94F.8010403-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/30/2011 09:29 AM, Wolfgang Grandegger wrote:
> On 11/30/2011 07:37 AM, Oliver Hartkopp wrote:
>> On 30.11.2011 00:39, David Miller wrote:
>>
>>> From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
>>> Date: Thu, 24 Nov 2011 13:07:26 +0100
>>>
>>>> Already since a while we have support for the Bosch CC770 and Intel
>>>> AN82527 CAN controllers in our out-of-tree Socket-CAN repository.
>>>> It would be nice if somebody could test the driver. Unfortunately,
>>>> I currently do not have hardware at hand. I have not yet ported the
>>>> OF platform driver as it needs further attaention due to the merge
>>>> of the platform and OF platform interface.
>>>>
>>>> Wolfgang Grandegger (2):
>>>>   can: cc770: add driver core for the Bosch CC770 and Intel AN82527
>>>>   can: cc770: legacy CC770 ISA bus driver
>>>
>>> All applied, thank you.
>>
>>
>> Hello Dave,
>>
>> this patchset was superseded for some time.
>>
>> We're currently in the v4 patchset (dated 2011-11-29).
> 
> I just sent v5...
> 
>> See http://patchwork.ozlabs.org/patch/128244/
>>
>> Do you want to revert the commit or should Wolfgang post a diff patch to get
>> to v4 ??
> 
> Reverting and applying v5 would make sense as there are many changes.
> 
> Did I do something wrong?

Well, yes, at least I forgot the CC to the devicetree and linuxppc-dev
list (due to a "signedoffcc = false" in my .gitconfig). Resending v5 in
a second.

Wolfgang.
