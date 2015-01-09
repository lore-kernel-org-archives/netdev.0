From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Fri, 9 Jan 2015 09:37:21 -0800
Message-ID: <CAADnVQKUNc4pu7W6Riies3tVeh848ihHidb3iM2UnbEmea-Y-Q@mail.gmail.com>
References: <cover.1420756324.git.tgraf@suug.ch> <7339e3bff124cecaf65cd04ea9bdc973c730ba34.1420756324.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:49312 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755589AbbAIRhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 12:37:42 -0500
Received: by mail-qg0-f43.google.com with SMTP id z107so10026863qgd.2
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 09:37:41 -0800 (PST)
In-Reply-To: <7339e3bff124cecaf65cd04ea9bdc973c730ba34.1420756324.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 8, 2015 at 2:47 PM, Thomas Graf <tgraf@suug.ch> wrote:
> +
> +struct vxlan_gbp {
> +} __packed;

empty struct ? seems unused.
looks good to me otherwise.
