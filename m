From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH net-next 3/4] r8152: remove clear_bp function
Date: Thu, 21 Aug 2014 21:29:28 +0400
Message-ID: <53F62C78.8040404@cogentembedded.com>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com> <1394712342-15778-19-Taiwan-albertk@realtek.com> <201408210131.s7L1VuAJ031162@rtits1.realtek.com> <0835B3720019904CB8F7AA43166CEEB2515BB5@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2515BB5-JIZ+AM9kKNzuvTFwvkocLypo8c9IxeqyAjHCUHv49ws@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/21/2014 06:12 AM, Hayes Wang wrote:

> [...]
>>>    	r8152b_disable_aldps(tp);
>>>
>>> -	rtl_clear_bp(tp);
>>>

>>      Why leave 2 empty lines? One is enough.

> The next patch would use another fucntion at the
> same location. I skip removing the empty line and
> re-adding it again. Is that better to do so? I would
> resend the patches if the answer is yes.

    Sorry, I haven't looked at your next patch, too big for me. :-)

> Best Regards,
> Hayes

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
