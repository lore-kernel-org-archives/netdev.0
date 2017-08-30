From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3 v10] Add support for rmnet driver
Date: Tue, 29 Aug 2017 18:05:57 -0700 (PDT)
Message-ID: <20170829.180557.1826943085634265902.davem@davemloft.net>
References: <1504054078-10173-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com, dcbw@redhat.com,
        jiri@resnulli.us, stephen@networkplumber.org,
        David.Laight@ACULAB.COM, marcel@holtmann.org, andrew@lunn.ch
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42974 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdH3BF6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 21:05:58 -0400
In-Reply-To: <1504054078-10173-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Tue, 29 Aug 2017 18:47:55 -0600

> I have updated the locking scheme as follows -

Series applied, but this is not how you write a header posting for a
patch set.

This posting is where you say at a high level what the patch series is
doing, how it is doing it, and why it is doing it that way.

You can explain what changes happened, and why, but that belongs
in the changelog at the end of this posting.  Here you've made
an explaination for one change the entire content of the text.

You not even saying what rmnet is, why we would want to add it to the
kernel, and what it's all about.  So now when someone tries to read
the merge commit that contains this text, they will have no context
about you and me talking about locking and they will thus ask
themselves "what is this person talking about here?  it's not
explaining the patch series at all"
