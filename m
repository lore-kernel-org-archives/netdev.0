From: Paul Menage <menage@google.com>
Subject: Re: [Devel] Re: [HELP] for using class group classifier network
	controller
Date: Mon, 22 Jun 2009 11:05:32 -0700
Message-ID: <6599ad830906221105t45a79e39k4457f469ea4376f9@mail.gmail.com>
References: <4C86297B4AC6554B8BA018F0806590CE01C8AFA5@email1>
	 <20090615113609.db5c0613.usui@mxm.nes.nec.co.jp>
	 <20090615103020.GA8894@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Minoru Usui <usui@mxm.nes.nec.co.jp>,
	=?EUC-KR?B?sejA57+t?= <gauri@etri.re.kr>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:28546 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756219AbZFVSFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 14:05:39 -0400
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id n5MI5bN2021883
	for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 19:05:38 +0100
Received: from yxe32 (yxe32.prod.google.com [10.190.2.32])
	by zps75.corp.google.com with ESMTP id n5MI5Y6f001590
	for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 11:05:35 -0700
Received: by yxe32 with SMTP id 32so671631yxe.21
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 11:05:34 -0700 (PDT)
In-Reply-To: <20090615103020.GA8894@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2009 at 3:30 AM, Thomas Graf<tgraf@infradead.org> wrote:
>
> That's right, both net_cls.classid and tc use integers in hexadecimal form
> for both, printing and parsing.

net_cls.classid accepts integers in hexadecimal or decimal, and
reports in decimal.

Paul
