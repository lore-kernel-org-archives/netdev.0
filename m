From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2] net: Fix coding style warnings and errors.
Date: Thu, 19 May 2016 11:48:59 -0700 (PDT)
Message-ID: <20160519.114859.762858537783024404.davem@redhat.com>
References: <1463534190-3327-1-git-send-email-amitg.b14@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: amitg.b14@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463534190-3327-1-git-send-email-amitg.b14@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amit Ghadge <amitg.b14@gmail.com>
Date: Wed, 18 May 2016 06:46:30 +0530

> This is a patch to clean checkpatch warnings and errors
> in the Space.c file.
> Clean up the following warnings and errors.
> 
> WARNING :
> * Block comments use * on subsequent lines
> * Missing a blank line after declarations
> * networking block comments don't use an empty /* line, use /*
> * please, no space before tabs
> * please, no spaces at the start of a line
> * line over 80 characters
> 
> ERROR :
> * code indent should use tabs where possible
> * space prohibited after that open parenthesis '('
> 
> Signed-off-by: Amit Ghadge <amitg.b14@gmail.com>

Applied.
