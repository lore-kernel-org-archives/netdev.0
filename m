From: David Ahern <dsahern@gmail.com>
Subject: Re: If bridge have no sub-interfaces, it's status may be still with
 'RUNNING'
Date: Tue, 24 Feb 2015 21:23:35 -0700
Message-ID: <54ED4E47.9070304@gmail.com>
References: <54DDCA99.4040401@windriver.com>	<20150213133056.3944c13e@uryu.home.lan>	<54E17853.8070106@windriver.com>	<54E210FF.2050502@gmail.com>,<20150216115137.5aa3f0cd@uryu.home.lan> <E66F6C44A7A6EA49ABFC80EA526506DF65AEAEB3@ALA-MBB.corp.ad.wrs.com> <54ED39B9.4090107@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
To: yzhu1 <Yanjun.Zhu@windriver.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37534 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595AbbBYEXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 23:23:39 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so2843426igj.4
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 20:23:39 -0800 (PST)
In-Reply-To: <54ED39B9.4090107@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/24/15 7:55 PM, yzhu1 wrote:
> Hi, Stephen && David
>
> Any update?

As I mentioned in my last response I see no problem with the existing 
behavior -- 3.18, 3.19 and 4.0-rc1. With all of them the bridge stays in 
the running state after all interfaces are removed.

David
