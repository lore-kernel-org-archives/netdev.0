From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 0/8] add TX timestamping via cmsg
Date: Wed, 30 Mar 2016 17:38:36 -0700
Message-ID: <20160331003744.GA3300@kafai-mba.local>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<willemb@google.com>, <edumazet@google.com>, <ycheng@google.com>,
	<ncardwell@google.com>, Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39818 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751598AbcCaAir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 20:38:47 -0400
Content-Disposition: inline
In-Reply-To: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 06:37:20PM -0400, Soheil Hassas Yeganeh wrote:
> I will follow up with another patch to enable timestamping for
> active TFO (client-side TCP Fast Open) and also setting packet
> mark via cmsgs.
Can you share more details on what 'setting packet mark' does?

Nice patches!
