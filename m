From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip link: use addattr_nest()/addattr_nest_end()
Date: Wed, 24 Dec 2014 12:27:01 -0800
Message-ID: <20141224122701.46a01aba@urahara>
References: <549130AD.6090407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:64640 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbaLXU1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 15:27:11 -0500
Received: by mail-pd0-f180.google.com with SMTP id w10so10430371pde.11
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 12:27:10 -0800 (PST)
In-Reply-To: <549130AD.6090407@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Dec 2014 15:28:45 +0800
Duan Jiong <duanj.fnst@cn.fujitsu.com> wrote:

> 
> Use addattr_nest() and addattr_nest_end() to simplify the code.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied to latest (which is after 3.18.0)
