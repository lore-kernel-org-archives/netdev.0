From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v10 11/11] ipv6: Add generic UDP Tunnel segmentation
Date: Wed, 28 Aug 2013 10:55:49 -0700
Message-ID: <CALnjE+p87D301m8oJ=rkJap44zcPkVp=YkThUT70fW1kkrQ9AQ@mail.gmail.com>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
	<1377667379-2315-12-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:47457 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753085Ab3H1Rzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 13:55:50 -0400
Received: by mail-qe0-f41.google.com with SMTP id x7so3703423qeu.0
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 10:55:49 -0700 (PDT)
In-Reply-To: <1377667379-2315-12-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 10:22 PM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> Similar to commit 731362674580cb0c696cd1b1a03d8461a10cf90a
> (tunneling: Add generic Tunnel segmentation)
>
Can we factor out ipv4-udp-tunnel code so that there is no duplicating code?
