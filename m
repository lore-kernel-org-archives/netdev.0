From: Chris Friesen <cbf123@mail.usask.ca>
Subject: Re: where is the ethernet device number determined?
Date: Thu, 12 May 2016 14:27:56 -0600
Message-ID: <5734E74C.9060409@mail.usask.ca>
References: <5734E226.6040706@mail.usask.ca> <CAM_iQpVmy4bAKB9jwd0+uetw6GZuxg4MOmOb4Zya31VUwRYDQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-no.shaw.ca ([64.59.134.9]:44248 "EHLO
	smtp-out-no.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbcELUgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 16:36:08 -0400
In-Reply-To: <CAM_iQpVmy4bAKB9jwd0+uetw6GZuxg4MOmOb4Zya31VUwRYDQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/2016 02:19 PM, Cong Wang wrote:
> On Thu, May 12, 2016 at 1:05 PM, Chris Friesen <cbf123@mail.usask.ca> wrote:

>> I hope this is a simple question...with legacy naming ethernet devices are
>> named ethX.  Where is that X determined?  I've been looking in
>> alloc_netdev_mqs() and friends, but haven't found it yet.
>
> __dev_alloc_name()

Much appreciated.

Chris
