From: Xiangyu Lu <luxiangyu@huawei.com>
Subject: Re: [PATCH 0/5] Backport to 3.10.y for fix CVE-2014-0181
Date: Mon, 16 Jun 2014 18:19:39 +0800
Message-ID: <539EC4BB.7020305@huawei.com>
References: <1402623070-26549-1-git-send-email-luxiangyu@huawei.com> <CAHA+R7P8-Jw30h99PHhHw3G+Pe085VOtVo5h_noVHhZSV==BNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <gregkh@linuxfoundation.org>, <stable@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7P8-Jw30h99PHhHw3G+Pe085VOtVo5h_noVHhZSV==BNA@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/6/14 1:04, Cong Wang wrote:
> On Thu, Jun 12, 2014 at 6:31 PM, Xiangyu Lu <luxiangyu@huawei.com> wrote:
>> Hi Greg,
>>      This backport fix CVE-2014-0181 which would still be vulnerable in
>> the latest 3.10.y, please add it.
> This is not how netdev works for stable. You need to check the
> FAQ:
>
> https://www.kernel.org/doc/Documentation/networking/netdev-FAQ.txt
>
> Q: How can I tell what patches are queued up for backporting to the
>     various stable releases?
>
> A: Normally Greg Kroah-Hartman collects stable commits himself, but
>     for networking, Dave collects up patches he deems critical for the
>     networking subsystem, and then hands them off to Greg.
>

OK, thanks! I will check it.
