From: Kiran Raparthy <kiran.kumar@linaro.org>
Subject: Re: [RFC 1/2] misc: uidstat: Add uid stat driver to collect network statistics.
Date: Tue, 20 Jan 2015 12:33:18 +0530
Message-ID: <CA+RfmHbK4FBZcwZ85HT-Zokv0P+XU7P5tXxH3tbyH-U_QjOh4w@mail.gmail.com>
References: <1421147642-28360-1-git-send-email-kiran.kumar@linaro.org>
	<20150113183441.GA24908@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>, Mike Chan <mike@android.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	Android Kernel Team <kernel-team@android.com>,
	John Stultz <john.stultz@linaro.org>,
	Sumit Semwal <sumit.semwal@linaro.org>,
	JP Abgrall <jpa@google.com>,
	=?UTF-8?B?QXJ2ZSBIau+/vW5uZXbvv71n?= <arve@android.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150113183441.GA24908@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14 January 2015 at 00:04, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> On Tue, Jan 13, 2015 at 04:44:01PM +0530, Kiran Raparthy wrote:
>> From: Mike Chan <mike@android.com>
>>
>> misc: uidstat: Add uid stat driver to collect network statistics.
>>
>> To analyze application's network statistics, we need a mechanism to export
>> the UID based statistics to userspace so that userspace tools can use the
>> exported numbers and generate the report against the UID.
>>
>> This patch allows the user to explore the UID based network statistics
>> exported to /proc/uid_stat.
>
> This is a joke, right?  It's not April 1 yet people, why send this in
> January?
>
> confused,

Hi Greg,
It was part of clearing the backlog,didn't realize that this is obsolete.
Please ignore the patch-set.
Regards,
Kiran

>
> greg k-h
