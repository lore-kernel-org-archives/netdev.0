From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 json v2 00/27] ip: add -json support to 'ip link
 show'
Date: Wed, 23 Aug 2017 23:51:26 +0200
Message-ID: <20170823215126.GC22713@nanopsycho>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, dsa@cumulusnetworks.com
To: Julien Fortin <julien@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:35952 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751093AbdHWVv3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 17:51:29 -0400
Received: by mail-wr0-f179.google.com with SMTP id f8so4362174wrf.3
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 14:51:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 17, 2017 at 07:35:47PM CEST, julien@cumulusnetworks.com wrote:
>From: Julien Fortin <julien@cumulusnetworks.com>
>
>This patch series adds json support to 'ip [-details] link show [dev DEV]'
>Each patch describes the json schema it adds and provides some examples.

Any plans to jsonify tc as well?
